--created by Seth, coded by Lyris
--Mextro Midas
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,4,4)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	c:EnableCounterPermit(0xbdb)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_COUNTER)
	e2:SetCondition(s.rccon)
	e2:SetTarget(s.rctg)
	e2:SetOperation(s.rcop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.ctcon)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_DISABLE)
	e5:SetCost(s.docost)
	e5:SetTarget(s.dotg)
	c:RegisterEffect(e5)
end
function s.mfilter(c)
	return c:IsSetCard(0xee5) and c:GetMutualLinkedGroupCount()>0
end
function s.efilter(e,te)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
function s.rccon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.rctg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.filter(c)
	return c:IsSetCard(0xee5) and c:IsType(TYPE_LINK)
end
function s.rcop(e,tp)
	Duel.Recover(tp,1000,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then c:AddCounter(0xbdb,math.min(10,Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_ONFIELD,nil))) end
end
function s.ctcon(_,_,eg)
	return eg:IsExists(Card.IsSetCard,1,nil,0xee5)
end
function s.ctop(e)
	e:GetHandler():AddCounter(0xbdb,1)
end
function s.tdtg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP))
end
function s.tdop()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
end
function s.docost(e,tp,_,_,_,_,_,_,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0xbdb,4,REASON_COST) end
	c:RemoveCounter(tp,0xbdb,4,REASON_COST)
end
function s.dotg(e,tp,_,_,_,_,_,_,chk)
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
	local b2=Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	if aux.SelectFromOptions(tp,{b1,1193},{b2,1131})<2 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetOperation(s.todeck)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil),1,0,0)
	else
		e:SetCategory(CATEGORY_DISABLE)
		e:SetOperation(s.negate)
	end
end
function s.todeck(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.negate(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	if not tc:IsType(TYPE_TRAPMONSTER) then return end
	local e3=e1:Clone()
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	tc:RegisterEffect(e3)
end
