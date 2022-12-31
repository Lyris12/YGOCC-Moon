--Sinnamon Trick
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,310105+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--ACTIVATE
function cid.filter(c)
	return c:IsSetCard(0xa34) and not c:IsPublic()
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsPlayerCanDraw(tp) and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_HAND,0,1,e:GetHandler())
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_HAND,0,1,63,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.SetTargetCard(g)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(#g)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,g,#g,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,#g)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local g,p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if Duel.Draw(p,d,REASON_EFFECT)>0 and #tg>0 then
		Duel.BreakEffect()
		if Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)==0 then return end
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if ct>0 then
			Duel.SortDecktop(p,p,ct)
		end
	end
end
