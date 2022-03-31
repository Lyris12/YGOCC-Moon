--Sigil Maid - Star
function c213370.initial_effect(c)
	aux.AddCodeList(c,213355)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(213370,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,213370)
	e1:SetCost(c213370.drcost)
	e1:SetTarget(c213370.drtg)
	e1:SetOperation(c213370.drop)
	c:RegisterEffect(e1)
	--lv change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(213370,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,213371)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c213370.tg)
	e1:SetOperation(c213370.op)
	c:RegisterEffect(e1)
	--todeck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(213370,3))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,213372)
	e3:SetCondition(c213370.tdcon)
	e3:SetTarget(c213370.tdtg)
	e3:SetOperation(c213370.tdop)
	c:RegisterEffect(e3)
end
function c213370.cfilter(c)
	return c:IsCode(213355) or aux.IsCodeListed(c,213355) and c:IsDiscardable()
end
function c213370.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		and Duel.IsExistingMatchingCard(c213370.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,c213370.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
function c213370.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c213370.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c213370.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lv=e:GetHandler():GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(213370,2))
	e:SetLabel(Duel.AnnounceLevel(tp,1,5,lv))
end
function c213370.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		c:RegisterEffect(e1)
	end
end
function c213370.tdfilter(c)
	return c:IsFaceup() and c:IsCode(213355)
end
function c213370.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c213370.tdfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function c213370.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function c213370.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
