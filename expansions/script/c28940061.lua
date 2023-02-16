--Igneous Elemerge, Candice
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	aux.AddFusionProcFun2(c,ref.rcmatfilter,ref.attmatfilter,true)
	--OnSummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	c:RegisterEffect(e1)
	
end
function ref.rcmatfilter(c) return c:IsRace(RACE_WARRIOR) end
function ref.attmatfilter(c) return c:IsFusionAttribute(ATTRIBUTE_FIRE) end

function ref.ssfilter(c,e,tp)
	return Elemerge.Is(c) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
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
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(function(e) return Duel.GetMatchingGroupCount(Card.IsAttribute,e:GetHandlerPlayer(),LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil,ATTRIBUTE_FIRE)*500 end)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetCode(EVENT_BE_PRE_MATERIAL)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetOperation(ref.grantop)
			e2:SetLabelObject(e1)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			g:GetFirst():RegisterEffect(e2)
		end
	end
end
function ref.grantop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=e:GetLabelObject():Clone()
	rc:RegisterEffect(e1)
end
