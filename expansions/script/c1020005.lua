--[[
Zero Arrival
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_CODEMAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE|LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED|LOCATION_GRAVE|LOCATION_HAND)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE,-2,OPINFO_FLAG_LOWER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local c=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_REMOVED|LOCATION_GRAVE|LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if c and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsFaceup() then
		local g=Duel.GetMatchingGroup(aux.AND(aux.NOT(Card.IsAttack),Card.IsFaceup),tp,0,LOCATION_MZONE,nil,c:GetAttack())
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
			local tg=g:Select(tp,1,1,nil)
			Duel.HintSelection(tg)
			local tc=tg:GetFirst()
			c:UpdateATK(-math.abs(tc:GetAttack()-c:GetAttack()),RESET_PHASE|PHASE_END,{e:GetHandler(),true})
		end
	end
end