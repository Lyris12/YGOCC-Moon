--Henrietta, Neon Whirlwind
local ref,id=GetID()
Duel.LoadScript("Marionightte.lua")
function ref.initial_effect(c)
	Marionightte.Induct(c,100)
	--Tempo
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(ref.spcon)
	e1:SetTarget(ref.sptg)
	e1:SetOperation(ref.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Recurr
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==Duel.GetTurnPlayer() end)
	e3:SetTarget(ref.sstg)
	e3:SetOperation(ref.ssop)
	c:RegisterEffect(e3)
end
ref.has_text_race=RACE_MACHINE+RACE_PSYCHO

--Tempo
function ref.spcfilter(c) return c:IsFaceup() and (c:GetBaseAttack()==1100 or c:GetBaseDefense()==1100) end
function ref.spcon(e,tp,eg,ep,ev,re,r,rp) return tp==rp and eg:IsExists(ref.spcfilter,1,nil) end
function ref.sptg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function ref.spop(e,tp) local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--Protect
function ref.prcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function ref.prtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
function ref.prop(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(ref.immtg)
	e1:SetValue(ref.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function ref.immtg(e,c)
	return c:IsCode(Marionightte.ID)
end
function ref.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end

--Summon
function ref.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e)
		and (Marionightte.RewardCount(tp)>=3
		or (c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE+RACE_PSYCHO)))
end
function ref.ssgfilter(g,e,tp,mc)
	return g:IsContains(mc) and g:IsExists(ref.ssfilter,1,nil,e,tp)
end
function ref.ssfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
	if not ref.tgfilter(c,e,tp) then return false end
	local g=Duel.GetMatchingGroup(ref.tgfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil,e,tp)
	g:AddCard(c)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(ref.ssgfilter,3,3,e,tp,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=g:SelectSubGroup(tp,ref.ssgfilter,false,3,3,e,tp,c)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,tp,LOCATION_REMOVED)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local sg=g:Filter(ref.ssfilter,nil,e,tp):Select(tp,1,1,nil)
		if #sg>0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
		g:Sub(sg)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
