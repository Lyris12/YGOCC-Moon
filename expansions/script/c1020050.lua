--Divinità Bushido Drago Terra
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x4b0),aux.NonTuner(Card.IsRace,RACE_BEASTWARRIOR),1)
	c:MustFirstBeSummoned(SUMMON_TYPE_SYNCHRO)
	--protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.efilter)
	c:RegisterEffect(e0)
	--destroy
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_DESTROY,EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DD,true,
		aux.SynchroSummonedCond,
		aux.ToDeckCost(s.cfilter,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,3),
		aux.Target(Card.IsFaceup,0,LOCATION_ONFIELD,1,1,nil,nil,CATEGORY_DESTROY),
		aux.DestroyOperation(SUBJECT_IT)
	)
	--protect other cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	c:RegisterEffect(e2)
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(0x4b0) and c:NotBanishedOrFaceup()
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.tgfilter(c)
	return c:IsSetCard(0x4b0) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and c:IsDiscardable(REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil)
	end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.DiscardHand(tp,s.tgfilter,1,1,REASON_EFFECT+REASON_DISCARD+REASON_REPLACE,nil)
		return true
	else
		return false
	end
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end