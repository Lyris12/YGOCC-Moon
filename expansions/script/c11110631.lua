--Lifeweaver's Overflow
--Esondazione della Vitatessitrice
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[Return 1 "Lifeweaver" Time Leap Monster you control to your Extra Deck, and if you do, banish up to 2 cards on the field.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[During your Main Phase, if you control a Future 4 "Lifeweaver" Time Leap Monster: You can shuffle this card into your Deck, and if you do, Set 1 "Lifeweaver" Spell from your GY.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
--FILTERS E1
function s.tdfilter(c,tp,exc0)
	local exc = type(exc0)~="nil" and Group.FromCards(c,exc0) or c
	return c:IsFaceup() and c:IsType(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsAbleToExtra()
		and (not tp or Duel.IsExists(false,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc))
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local exc=aux.ActivateException(e,chk)
		return Duel.IsExists(false,s.tdfilter,tp,LOCATION_MZONE,0,1,nil,tp,exc)
	end
	local g1=Duel.Group(s.tdfilter,tp,LOCATION_MZONE,0,nil,nil)
	local g2=Duel.Group(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Select(HINTMSG_TODECK,false,tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,aux.ExceptThis(c))
	if #g<=0 then
		g=Duel.Select(HINTMSG_TODECK,false,tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,nil)
	end
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and aux.PLChk(tc,tp,LOCATION_EXTRA) then
			local sg=Duel.Select(HINTMSG_REMOVE,false,tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,aux.ExceptThis(c))
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Banish(sg)
			end
		end
	end
end

--FILTERS E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_TIMELEAP) and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsFuture(4)
end
function s.setfilter(c)
	return c:IsSpell() and c:IsSetCard(ARCHE_LIFEWEAVER) and c:IsSSetable()
end
--E2
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.Necro(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g:GetFirst())
		end
	end
end