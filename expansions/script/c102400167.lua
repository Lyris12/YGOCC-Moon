--created & coded by Lyris, art by JetBlackStare77 of DeviantArt
--ニュートリックス・ベキー
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetCountLimit(1,id)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(cid.tg)
	e2:SetOperation(cid.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function cid.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xd10) and not c:IsCode(id)
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,2,nil)
		and Duel.IsPlayerCanDraw(tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	local ct=#g:Filter(cid.filter,nil)
	if ct>0 then Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct) end
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local cg=g:Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	local nc=#cg:Filter(cid.filter,nil)
	if #cg==#tg and nc>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,nc,REASON_EFFECT)
	end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsType(TYPE_LINK) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,TYPE_LINK) end
	Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,TYPE_LINK)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	for tc in aux.Next(g) do
		local lpt,nlpt=tc:GetLinkMarker(),0
		local j=0
		for i=0,8 do
			j=0x1<<i&lpt
			if j>0 and cid.link_table[j] then
				nlpt=nlpt|cid.link_table[j]
			end
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
		e1:SetValue(nlpt)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
cid.link_table={
	[LINK_MARKER_BOTTOM_LEFT]=LINK_MARKER_LEFT,
	[LINK_MARKER_BOTTOM]=LINK_MARKER_BOTTOM_LEFT,
	[LINK_MARKER_BOTTOM_RIGHT]=LINK_MARKER_BOTTOM,
	[LINK_MARKER_LEFT]=LINK_MARKER_TOP_LEFT,
	[LINK_MARKER_RIGHT]=LINK_MARKER_BOTTOM_RIGHT,
	[LINK_MARKER_TOP_LEFT]=LINK_MARKER_TOP,
	[LINK_MARKER_TOP]=LINK_MARKER_TOP_RIGHT,
	[LINK_MARKER_TOP_RIGHT]=LINK_MARKER_RIGHT,
}
