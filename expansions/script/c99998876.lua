--created by Walrus, coded by XGlitchy30
--Voidictator Rune - Void Renewal
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(s.condition,nil,s.target,s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:HOPT()
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_VOIDICTATOR)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_VOIDICTATOR_RUNE_COURT_OF_THE_VOID),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_VOIDICTATOR_RUNE_GATES_OF_PERDITION),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
function s.chfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_VOIDICTATOR_DEITY_NEMESIS)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetDecktopGroup(tp,3)
	if chk==0 then
		return rg:FilterCount(Card.IsAbleToRemove,nil)==3 and Duel.IsExists(false,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,3,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not s.condition(e,tp,eg,ep,ev,re,r,rp) then return end
	local g=Duel.Group(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local rg=Duel.GetDecktopGroup(tp,3)
		local rgf=rg:Filter(Card.IsAbleToRemove,nil)
		if #rg>0 and #rg==#rgf then
			Duel.DisableShuffleCheck()
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rc and aux.CheckArchetypeReasonEffect(s,re,ARCHE_VOIDICTATOR) and rc:IsOwner(tp)
end
function s.filter(c)
	return c:IsSetCard(ARCHE_VOIDICTATOR) and not c:IsCode(id) and (c:IsAbleToHand() or c:IsAbleToRemove())
end
function s.gcheck(sg,e,tp,mg,c)
	if #sg<2 then return true end
	local first=sg:GetFirst()
	if first==c then
		first=sg:GetNext()
	end
	return (first:IsAbleToHand() and c:IsAbleToRemove()) or (c:IsAbleToHand() and first:IsAbleToRemove())
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.filter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.gcheck,1,tp,HINTMSG_OPERATECARD,nil,nil,false)
	if #sg==2 then
		Duel.HintMessage(tp,HINTMSG_ATOHAND)
		local tc=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil):GetFirst()
		if tc and Duel.SearchAndCheck(tc,tp) then
			sg:RemoveCard(tc)
			Duel.BreakEffect()
			Duel.Remove(sg:GetFirst(),POS_FACEUP,REASON_EFFECT)
		end
	end
end
