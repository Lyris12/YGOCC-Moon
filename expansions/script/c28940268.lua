--Autice, Spectral Vivisection
local ref,id=GetID()
Duel.LoadScript("Marionightte.lua")
function ref.initial_effect(c)
	Marionightte.Induct(c,100)
	--Handtrap
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetRange(LOCATION_HAND)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCondition(ref.sscon)
	e0:SetTarget(ref.sstg)
	e0:SetOperation(ref.ssop)
	c:RegisterEffect(e0)
	--Banish
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	--e1:SetCondition(ref.rmcon)
	e1:SetCost(ref.rmcost)
	e1:SetTarget(ref.rmtg)
	e1:SetOperation(ref.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
ref.has_text_race=RACE_MACHINE+RACE_ZOMBIE

--Handtrap
function ref.sscon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA)
end
function ref.actfilter(c,tp)
	return c:IsCode(Marionightte.ID) and c:GetActivateEffect():IsActivatable(tp)
		and not Duel.IsExistingMatchingCard(ref.notfilter,tp,LOCATION_ONFIELD,0,1,nil,c:GetOriginalCode())
end
function ref.notfilter(c,code)
	return c:IsFaceup() and c:GetOriginalCode()==code
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0
		and Duel.GetLocationCount(tp,LOCATION_SZONE,0)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(ref.actfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function ref.ssop(e,tp) local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(ref.actfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE,0)>0
	and c:IsRelateToEffect(e) and #g>0 and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			local tc=sg:GetFirst()
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
		end
		if Marionightte.RewardCount(tp)<3 then Duel.Destroy(c,REASON_EFFECT) end
	end
end

--Banish
function ref.rmcon(e,tp)
	return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler(),RACE_MACHINE+RACE_ZOMBIE)
end
function ref.rmcfilter(c) return c:IsRace(RACE_MACHINE+RACE_ZOMBIE) and c:IsAbleToRemove() end
function ref.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.rmcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,ref.rmcfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsAbleToRemove(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function ref.rmop(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end
