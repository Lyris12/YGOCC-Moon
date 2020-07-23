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
end
function cid.filter(c,tp)
	return c:IsSetCard(0xc74) and c:IsType(TYPE_MONSTER) and (c:IsAbleToDeck() or c:IsCanOverlay(tp))
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc,tp) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,0,5,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,0,5,5,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,2,0,0)
end
function cid.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x2c74)
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
			end
		end
	end
end
