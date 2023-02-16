--Gardrenial Cycle - Spring
local ref,id=GetID()
Duel.LoadScript("GardrenialCommons.lua")
function ref.initial_effect(c)
	Gardrenial.EnableTrackers(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
end

function ref.ssfilter(c,e,tp) return c:IsRace(RACE_INSECT) and c:IsLevelBelow(4)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.setfilter(c) return Gardrenial.Is(c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(c) end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not (Gardrenial.NSPlant(tp) or Gardrenial.NSInsect(tp)) then return false end
		local res1=true
		local res2=true
		if Gardrenial.NSPlant(tp) then res1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
		if Gardrenial.NSInsect(tp) then res2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(ref.setfilter,tp,LOCATION_DECK,0,1,nil) end
		return res1 and res2
	end
	if Gardrenial.NSPlant(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
	if Gardrenial.NSInsect(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(ref.chainlimit)
	end
end
function ref.chainlimit(e,rp,tp)
	return not e:IsActiveType(TYPE_MONSTER)
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	if Gardrenial.NSPlant(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetLabelObject(tc)
			e1:SetOperation(ref.sumop)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_END)
			e2:SetLabelObject(e1)
			e2:SetOperation(ref.cedop)
			Duel.RegisterEffect(e2,tp)
		end
		Duel.SpecialSummonComplete()
	end
	if Gardrenial.NSInsect(tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,ref.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 and Duel.SSet(tp,g)~=0 and g:GetFirst():IsType(TYPE_TRAP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end
function ref.sumop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetLabelObject()) then
		e:SetLabel(1)
		e:Reset()
	else e:SetLabel(0) end
end
function ref.cedop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) and e:GetLabelObject():GetLabel()==1 then
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	e:Reset()
end
