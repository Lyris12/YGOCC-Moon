--Holy Elemerge, Divis
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	aux.AddFusionProcFun2(c,ref.rcmatfilter,ref.attmatfilter,true)
	--OnSummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
	e1:SetCost(ref.sscost)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	
end
function ref.rcmatfilter(c) return c:IsRace(RACE_FAIRY) end
function ref.attmatfilter(c) return c:IsFusionAttribute(ATTRIBUTE_LIGHT) end

--Summon
function ref.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	Duel.DiscardHand(tp,nil,1,1,REASON_COST,nil)
end
function ref.ssfilter(c,e,tp)
	return Elemerge.Is(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and not c:IsCode(id)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetChainLimit(function(e,rp,tp) return tp==rp
		or not (e:IsActiveType(TYPE_MONSTER) and e:GetHandler():IsAttribute(ATTRIBUTE_LIGHT)) end)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local c=e:GetHandler()
			local e0=Effect.CreateEffect(c)
			e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e0:SetTargetRange(1,0)
			e0:SetTarget(function(e,c) return c:IsCode(id) end)
			e0:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e0,tp)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetTargetRange(0,1)
			e1:SetValue(ref.aclimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function ref.limfilter(c) return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) end
function ref.aclimit(e,re,tp)
	return Duel.GetActivityCount(tp,ACTIVITY_CHAIN) <=
		Duel.GetMatchingGroupCount(ref.limfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
end
