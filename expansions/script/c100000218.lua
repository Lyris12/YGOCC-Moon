--[[
Crimson Knight of Verdanse
Cavaliere Cremisi di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,id,CARD_RUM_RITUAL_OF_VERDANSE)
	--[[If this card is Ritual Summoned: You can target 1 DARK "Number" Xyz Monster in your GY; Special Summon that target, and if you do, attach 2 "Verdanse" Ritual Monsters from your hand and/or GY to it as materials. (This is treated as an Xyz Summon.)]]
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
	--[[During damage calculation, if this card battles (Quick Effect): You can target 1 DARK Xyz Monster you control that has material;
	this card gains 1200 ATK for each material attached to it during that damage calculation only.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantBattleTimings()
	e2:SetFunctions(
		s.atkcon,
		nil,
		s.atktg,
		s.atkop)
	c:RegisterEffect(e2)
	--[[While you control a DARK "Number" Xyz Monster, this card's original ATK/DEF become 3800/1000, also negate the effects of all monsters your opponent controls during the Battle Phase only.]]
	local cond=aux.LocationGroupCond(s.filter,LOCATION_MZONE,0,1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cond)
	e3:SetValue(3800)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_BASE_DEFENSE)
	e4:SetValue(1000)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(aux.AND(cond,aux.BattlePhaseCond()))
	c:RegisterEffect(e5)
end
--E1
function s.xyzfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xmatfilter(c,tp)
	return c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE) and c:IsCanOverlay(tp)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.xyzfilter(chkc,e,tp) end
	if chk==0 then
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) and Duel.GetMZoneCount(tp)>0
			and Duel.IsExists(true,s.xyzfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.IsExists(false,s.xmatfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,2,nil,tp)
	end
	local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.xyzfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and s.xyzfilter(tc,e,tp) then
		tc:SetMaterial(nil)
		if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
			if not tc:IsType(TYPE_XYZ) then return end
			local sg=Duel.Select(HINTMSG_XMATERIAL,false,tp,aux.Necro(s.xmatfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,2,2,nil,tp)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Attach(sg,tc)
			end
		end
	end
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetBattleMonster(tp)
	return a and a==e:GetHandler() and a:IsRelateToBattle() and a:IsFaceup()
end
function s.atkfilter(c,h)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)) then return false end
	local ct=c:GetOverlayCount()
	return ct>0 and h:IsCanChangeAttack(ct*1200)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter(chkc,c) end
	if chk==0 then
		return Duel.IsExists(true,s.atkfilter,tp,LOCATION_MZONE,0,1,nil,c)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil,c)
	local p,loc=c:GetResidence()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,p,loc,g:GetFirst():GetOverlayCount()*1200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and tc:IsRelateToChain() and tc:IsType(TYPE_XYZ) then
		local val=math.max(0,tc:GetOverlayCount()*1200)
		c:UpdateATK(val,RESET_PHASE|PHASE_DAMAGE_CAL,c)
	end
end

--E3
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end