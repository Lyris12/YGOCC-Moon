--MMS - Mastema, the Hateful Angel
--MMS - Mastema, l'Angelo Rancoroso
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_LIGHT),s.matfilter,2,2,true)
	c:EnableReviveLimit()
	--If this card is Special Summoned: You can negate the effects of all cards your opponent currently controls, until the end of the turn.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--If an "MMS -" Fusion Monster(s) you control would be destroyed by an opponent's card effect, you can shuffle 3 of your banished "MMS -" cards into the Deck, instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
function s.matfilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(ARCHE_MMS) and (not sg or sg:IsExists(Card.IsLevelAbove,1,nil,5))
end
--E1
function s.filter(c,e)
	return aux.NegateAnyFilter(c) and c:IsCanBeDisabledByEffect(e,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DISABLE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD,nil,e)
	if #g==0 then return end
	for tc in aux.Next(g) do
		Duel.Negate(tc,e,RESET_PHASE|PHASE_END)
	end
end

--E2
function s.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_MMS) and c:IsAbleToDeck()
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) 
		and c:IsType(TYPE_FUSION) and c:IsSetCard(ARCHE_MMS)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.tdfilter,tp,LOCATION_REMOVED,0,3,eg) and eg:IsExists(s.repfilter,1,nil,tp) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local g=Duel.Select(HINTMSG_TODECK,false,tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,eg)
		if #g>0 then
			Duel.HintSelection(g)
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
	end
	return false
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_REPLACE)
		g:DeleteGroup()
	end
end