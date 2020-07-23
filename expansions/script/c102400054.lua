--created & coded by Lyris, art from Cardfight!! Vanguard's "Spiral Master"
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(cid.reptg)
	e2:SetValue(cid.repval)
	e2:SetOperation(cid.repop)
	c:RegisterEffect(e2)
end
function cid.filter(c,tp)
	return c:IsSetCard(0xc74) and c:IsType(TYPE_MONSTER) and (c:IsAbleToDeck() or c:IsCanOverlay(tp))
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc,tp) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsExistingMatchingCard(cid.xfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,0,5,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,0,5,5,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,0,0)
end
function cid.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)<3 then return end
	Duel.SendtoDeck(tg:Select(tp,3,3,nil),nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		if Duel.Draw(tp,2,REASON_EFFECT)==0 then return end
		local xg=tg:Filter(Card.IsRelateToEffect,nil,e)
		for i=1,#xg do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local xc=Duel.SelectMatchingCard(tp,cid.xfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
			if xc then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				local oc=xg:Select(tp,1,1,nil)
				Duel.Overlay(xc,oc)
				xg:Sub(oc)
			else break end
		end
	end
end
function cid.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc74) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and not c:IsReason(REASON_REPLACE)
end
function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(cid.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function cid.repval(e,c)
	return cid.repfilter(c,e:GetHandlerPlayer())
end
function cid.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
