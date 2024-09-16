--[[
Dynastygian Satellite - "Beholder"
Satellite Dinastigiano - "Osservatore"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	--Special Summon (from your Extra Deck) by Tributing 1 Level 4 or lower DARK monster you control while you control a Continuous Spell/Trap.
	local proc=Effect.CreateEffect(c)
	proc:SetDescription(id,0)
	proc:SetType(EFFECT_TYPE_FIELD)
	proc:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	proc:SetCode(EFFECT_SPSUMMON_PROC)
	proc:SetRange(LOCATION_EXTRA)
	proc:SetCondition(s.hspcon)
	proc:SetTarget(s.hsptg)
	proc:SetOperation(s.hspop)
	c:RegisterEffect(proc)
	--Summoning condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.linklimit)
	c:RegisterEffect(e1)
	--[[If this card is Link Summoned, or if another DARK monster(s) is Special Summoned from your hand or GY to your field:
	You can add 1 "Dynastygian" card or "Rank-Up-Magic" Spell from your Deck or GY to your hand.]]
	local sptg=xgl.SearchTarget(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	local spop=xgl.SearchOperation(s.thfilter,LOCATION_DECK|LOCATION_GRAVE)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		aux.LinkSummonedCond,
		nil,
		sptg,
		spop
	)
	c:RegisterEffect(e2)
	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SHOPT()
	e3:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e3:SetFunctions(
		aux.AlreadyInRangeEventCondition(s.spcfilter),
		nil,
		sptg,
		spop
	)
	c:RegisterEffect(e3)
	--[[During your Main Phase, if you control a DARK "Number" Xyz Monster that has a number between "201" and "214" in its name: You can target 1 DARK "Number" Xyz Monster you control
	and 2 other cards on your field, GY and/or banishment; attach those cards to the first target as materials, and if you do, for the rest of this turn after this effect resolves,
	that target gains 300 ATK x the number of materials attached to it.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,2)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetCustomCategory(CATEGORY_ATTACH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(
		aux.LocationGroupCond(s.numfilter,LOCATION_MZONE,0,1),
		nil,
		s.attg,
		s.atop
	)
	c:RegisterEffect(e4)
end
--PROC
function s.cfilter(c,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK) and Duel.GetMZoneCount(tp,c)>0
end
function s.cfilter2(c)
	return c:IsFaceup() and c:IsST(TYPE_CONTINUOUS)
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExists(false,s.cfilter2,tp,LOCATION_ONFIELD,0,1,nil) and Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_SPSUMMON,false,nil,tp)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.cfilter,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_SPSUMMON)
end

--E2
function s.thfilter(c)
	return c:IsSetCard(ARCHE_DYNASTYGIAN) or (c:IsSetCard(ARCHE_RUM) and c:IsSpell())
end

--E3
function s.spcfilter(c,_,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND|LOCATION_GRAVE)
end

--E4
function s.numfilter(c)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)) then return false end
	local n=aux.GetXyzNumber(c)
	return n>=201 and n<=214
end
function s.atchfilter(c,xyzc,e,tp)
	return c:IsCanBeAttachedTo(xyzc,e,tp,REASON_EFFECT)
end
function s.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and Duel.IsExists(true,s.atchfilter,tp,LOCATION_ONFIELD|LOCATION_GB,0,1,c,c,e,tp)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExists(true,s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	local eid=e:GetFieldID()
	Duel.SetTargetParam(eid)
	local xyzc=Duel.Select(HINTMSG_ATTACHTO,true,tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	xyzc:RegisterFlagEffect(id,RESET_CHAIN,0,0,eid)
	local g=Duel.Select(HINTMSG_ATTACH,true,tp,s.atchfilter,tp,LOCATION_ONFIELD|LOCATION_GB,0,2,2,xyzc,xyzc,e,tp)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,#g,0,0,xyzc)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,xyzc,1,0,0,(xyzc:GetOverlayCount()+2)*300)
end
function s.tgcheck(xyzc)
	return not xyzc:IsFaceup() or not xyzc:IsType(TYPE_XYZ) or not xyzc:IsSetCard(ARCHE_NUMBER) or not xyzc:IsAttribute(ATTRIBUTE_DARK)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	local xyzc=g:Filter(Card.HasFlagEffectLabel,nil,id,Duel.GetTargetParam()):GetFirst()
	if not xyzc or not xyzc:IsControler(tp) or s.tgcheck(xyzc) then return end
	g:RemoveCard(xyzc)
	if #g==0 then return end
	if Duel.Attach(g,xyzc,false,e,REASON_EFFECT,tp)>0 and xyzc:IsRelateToChain() and not s.tgcheck(xyzc) then
		local atk=xyzc:GetOverlayCount()*300
		if atk==0 then return end
		xyzc:UpdateATK(atk,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
	end
end