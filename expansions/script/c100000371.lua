--[[
Vacuous Archfiend
Arcidemone Vacuo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_POWER_VACUUM_ZONE,CARD_POWER_VACUUM_BLADE)
	aux.AddMaterialCodeList(c,CARD_VACUOUS_MONARCH)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterEqualFunction(Card.GetBaseAttack,0),aux.FilterBoolFunction(Card.IsCode,CARD_VACUOUS_MONARCH),1,1)
	--[[If this card is Synchro Summoned: You can target 2 Level 5 "Vacuous" monsters in your GY and/or banishment; Special Summon those targets in Defense Position.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.SynchroSummonedCond,
		nil,
		xgl.SpecialSummonTarget(TGCHECK_THAT_TARGET,s.spfilter,LOCATION_GB,0,2,2,nil,nil,nil,nil,nil,nil,POS_FACEUP_DEFENSE),
		xgl.SpecialSummonOperation(TGCHECK_THAT_TARGET,s.spfilter,LOCATION_GB,0,2,2,nil,nil,nil,nil,nil,nil,POS_FACEUP_DEFENSE)
	)
	c:RegisterEffect(e1)
	--[[Up to thrice per turn: You can target 1 card your opponent controls; negate its effects, and if you do, banish it when it leaves the field. This is a Quick Effect if you control "Power Vacuum
	Zone".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3)
	e2:SetFunctions(
		nil,
		nil,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e2)
	local e2q=e2:QuickEffectClone(c,aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_ZONE),LOCATION_ONFIELD,0,1))
	e2:SetLabelObject(e2q)
	e2q:SetLabelObject(e2)
	--[[While this card is equipped with "Power Vacuum Blade", it can attack on all monsters your opponent controls during each Battle Phase, once each.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
--E1
function s.spfilter(c)
	return c:IsFaceupEx() and c:IsLevel(5) and c:IsSetCard(ARCHE_VACUOUS)
end

--E2
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	e:GetLabelObject():UseCountLimit(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		local e1,e2,e3,res=Duel.Negate(tc,e)
		if res==nil then res=e3 end
		if res then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(STRING_BANISH_REDIRECT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
			tc:RegisterEffect(e1,true)
		end
	end
end

--E3
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(aux.FaceupFilter(Card.IsCode,CARD_POWER_VACUUM_BLADE),1,nil)
end