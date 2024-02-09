--Karasu, Ali Nottesfumo della Decadenza
--Script by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	--zone limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.limitcon)
	e1:SetOperation(s.limitzone)
	c:RegisterEffect(e1)
	--mill
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end

--filters
function s.matfilter(c)
	return c:IsLinkSetCard(ARCHE_NIGHTSHADE) and c:IsLinkType(TYPE_EFFECT) and not c:IsLinkType(TYPE_LINK)
end
function s.cfilter(c,g)
	return c:IsSetCard(ARCHE_NIGHTSHADE) and c:IsType(TYPE_XYZ) and g:IsContains(c)
end
function s.tgfilter(c)
	return c:IsSetCard(ARCHE_NIGHTSHADE) and c:IsAbleToGrave()
end
--zone limit
function s.limfilter(c,tp,g)
	return g:IsContains(c) and c:IsSummonPlayer(tp) and (c:IsFacedown() or not c:IsSetCard(ARCHE_NIGHTSHADE))
end
function s.limitcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp,e:GetHandler():GetLinkedGroup())
end
function s.limitzone(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.limfilter,nil,tp,e:GetHandler():GetLinkedGroup())
	if #g>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_RULE)
	end
end

--mill
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,lg) end
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,lg)
	Duel.Release(g,REASON_COST)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end