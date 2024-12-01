--[[
Galactic CODEMAN: Flare Blitzer
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--fusion material
	aux.AddFusionProcFun2(c,s.ffilter,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST|REASON_MATERIAL)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_FUSION)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT(true)
	e1:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e1:SetCondition(aux.AlreadyInRangeEventCondition(s.cfilter))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT(true)
	e2:SetCondition(s.bancon)
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
end
function s.ffilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFusionSetCard(ARCHE_CODEMAN)
end

--E0
function s.splimit(e,se,sp,st)
	if not e:GetHandler():IsLocation(LOCATION_EXTRA) then return true end
	local sc=se:GetHandler()
	local code,code2=sc:GetCode()
	if Duel.GetCurrentChain()>0 then
		code,code2=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	end
	return (se and se:IsHasType(EFFECT_TYPE_ACTIONS) and ((aux.CheckArchetypeReasonEffect(s,se,ARCHE_FUSION) and se:IsActiveType(TYPE_SPELL)) or (code==1020101 or code2==1020101)))
end

--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CODEMAN) and c:IsControler(tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_CODEMAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0,-2,OPINFO_FLAG_HALVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsFaceup() then
			c:HalveATK(true)
		end
	end
end

--E2
function s.atkcheck(c)
	return not c:IsAttack(c:GetBaseAttack())
end
function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,nil)
	return #g>=2 and g:IsExists(s.atkcheck,1,nil)
end
function s.banfilter(c,e,tp)
	return c:IsSetCard(ARCHE_CODEMAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.banfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
