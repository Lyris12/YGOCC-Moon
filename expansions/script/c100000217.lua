--[[
Dancer of Verdanse
Ballerina di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,id,CARD_RUM_RITUAL_OF_VERDANSE)
	--[[If this card is Ritual Summoned: You can target 1 DARK "Number" Xyz Monster in your GY; Special Summon that target, and if you do,
	attach 2 cards your opponent controls and up to 3 Level 5 "Verdanse" Ritual Monsters from your hand and/or GY to it as materials. (This is treated as an Xyz Summon.)]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.RitualSummonedCond)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	--[[During damage calculation, if a DARK Xyz Monster you control battles an opponent's monster (Quick Effect): You can discard 1 "Verdanse" Ritual Monster;
	that DARK Xyz Monster gains ATK equal to the ATK of that opponent's monster during damage calculation only.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantBattleTimings()
	e2:SetFunctions(
		s.atkcon,
		aux.DiscardCost(s.cfilter),
		s.atktg,
		s.atkop)
	c:RegisterEffect(e2)
	--[[While you control a DARK "Number" Xyz Monster, this card can make up to 3 attacks on monsters during the Battle Phase,
	also if this card attacks a Defense Position monster, inflict piercing battle damage to your opponent.]]
	local cond=aux.LocationGroupCond(s.filter,LOCATION_MZONE,0,1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cond)
	e3:SetValue(2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	e4:SetCondition(cond)
	c:RegisterEffect(e4)
end
--E1
function s.xyzfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xmatfilter(c,tp)
	if not c:IsCanOverlay(tp) then return false end
	if c:IsControler(tp) then
		return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsLevel(5)
	elseif c:IsControler(1-tp) then
		return true
	end
	return false
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.xyzfilter(chkc,e,tp) end
	if chk==0 then
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) and Duel.GetMZoneCount(tp)>0
			and Duel.IsExists(true,s.xyzfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.IsExists(false,Card.IsCanOverlay,tp,0,LOCATION_ONFIELD,2,nil,tp)
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.xyzfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.gcheck(g,e,tp)
	return g:FilterCount(Card.IsControler,nil,1-tp)==2
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and s.xyzfilter(tc,e,tp) then
		tc:SetMaterial(nil)
		if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
			if not tc:IsType(TYPE_XYZ) then return end
			local g=Duel.Group(aux.Necro(s.xmatfilter),tp,LOCATION_HAND|LOCATION_GRAVE,LOCATION_ONFIELD,nil,tp)
			if aux.SelectUnselectGroup(g,e,tp,2,5,s.gcheck,0) then
				local sg=aux.SelectUnselectGroup(g,e,tp,2,5,s.gcheck,1,tp,HINTMSG_XMATERIAL,s.gcheck,false,false)
				if #sg>0 then
					Duel.HintSelection(sg)
					Duel.Attach(sg,tc)
				end
			end
		end
	end
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a,b=Duel.GetBattleMonster(tp),Duel.GetBattleMonster(1-tp)
	return a and a:IsRelateToBattle() and a:IsFaceup() and a:IsType(TYPE_XYZ) and a:IsSetCard(ARCHE_NUMBER) and a:IsAttribute(ATTRIBUTE_DARK)
		and b and b:IsRelateToBattle()
end
function s.cfilter(c)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a,b=Duel.GetBattleMonster(tp),Duel.GetBattleMonster(1-tp)
	if chk==0 then
		return b:IsFaceup() and b:IsAttackAbove(1) and a:IsCanChangeAttack(b:GetAttack())
	end
	Duel.SetTargetCard(Group.FromCards(a,b))
	local p,loc=a:GetResidence()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,a,1,p,loc,b:GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a,b=Duel.GetBattleMonster(tp),Duel.GetBattleMonster(1-tp)
	if a and a:IsRelateToBattle() and a:IsFaceup() and a:IsType(TYPE_XYZ) and a:IsSetCard(ARCHE_NUMBER) and a:IsAttribute(ATTRIBUTE_DARK) and a:IsRelateToChain()
		and b and b:IsRelateToBattle() and b:IsFaceup() and b:IsRelateToChain() then
		local val=math.max(0,b:GetAttack())
		a:UpdateATK(val,RESET_PHASE|PHASE_DAMAGE_CAL,{e:GetHandler(),true})
	end
end

--E3
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end