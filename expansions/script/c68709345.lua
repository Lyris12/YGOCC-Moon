--Peashy, CPU Goddess
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.tgcost)
	e1:SetTarget(cid.tgtg)
	e1:SetOperation(cid.tgop)
	c:RegisterEffect(e1)
	--material effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(cid.lkcon)
	e2:SetOperation(cid.lkop)
	c:RegisterEffect(e2)
end
--SEARCH
function cid.costfilter(c,tp,cc)
	return c:IsDiscardable() and c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(cid.scfilter,tp,LOCATION_DECK,0,1,Group.FromCards(c,cc),c:GetCode(),cc:GetCode())
end
function cid.scfilter(c,...)
	local f={...}
	return c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and (#f<=0 or not c:IsCode(table.unpack(f)))
end
------
function cid.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return e:GetHandler():IsDiscardable() and Duel.IsExistingMatchingCard(cid.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),tp,e:GetHandler())		
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,cid.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),tp,e:GetHandler())
	g:AddCard(e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.tgop(e,tp,eg,ep,ev,re,r,rp)
	local f={}
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if #tg>0 then
		local tc=tg:GetFirst()
		while tc do
			table.insert(f,tc:GetCode())
			tc=tg:GetNext()
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.scfilter,tp,LOCATION_DECK,0,1,1,nil,table.unpack(f))
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--MATERIAL EFFECT
function cid.lkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return r==REASON_LINK and rc:IsSetCard(0xf09) and rc:IsLinkAbove(3)
end
function cid.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--extra effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(cid.spincon)
	e1:SetCost(cid.spincost)
	e1:SetTarget(cid.spintg)
	e1:SetOperation(cid.spinop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end

--EXTRA EFFECT
function cid.spincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function cid.cfilter(c)
	return c:IsSetCard(0xf08) and c:IsDiscardable()
end
function cid.spincost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,cid.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function cid.filter(c)
	if not c:IsAbleToDeck() then return false end
	return c:IsFacedown() or c:IsType(TYPE_MONSTER)
end
function cid.spintg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function cid.spinop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end