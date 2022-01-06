--Ennigmatic Aura
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(cid.target)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(cid.drcon)
	e2:SetTarget(cid.drtg)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
	--attach
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(cid.attachcon)
	e3:SetTarget(cid.attachtg)
	e3:SetOperation(cid.attachop)
	c:RegisterEffect(e3)
end
--filters
function cid.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xead) and c:IsType(TYPE_XYZ)
end
function cid.tgfilter(c,eg)
	return (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) and c:IsType(TYPE_MONSTER)
		and eg:IsExists(cid.cfilter,1,nil)
end
function cid.rvfilter(c)
	return c:IsAbleToDeck() and not c:IsPublic()
end
--Activate
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.IsExistingMatchingCard(cid.rvfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)<=0
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e:SetOperation(cid.activate)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,cid.rvfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
		if g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
			if g:GetFirst():IsLocation(LOCATION_DECK) then
				Duel.ShuffleDeck(tp)
			end
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			if Duel.Draw(p,d,REASON_EFFECT)>0 then
				local tc=Duel.GetOperatedGroup():GetFirst()
				if tc:IsSetCard(0xead) and not tc:IsPublic() and Duel.IsPlayerCanDraw(tp,1) then
					Duel.BreakEffect()
					Duel.ConfirmCards(1-tp,tc)
					Duel.Draw(p,1,REASON_EFFECT)
				end
			end
		end
	end
end
function cid.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.rvfilter,tp,LOCATION_HAND,0,1,nil) 
		and Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)<=0 
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
--attach
function cid.attachcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter,1,nil)
end
function cid.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED+LOCATION_GRAVE) and chkc:IsControler(tp) and cid.tgfilter(chkc,eg) end
	if chk==0 then return Duel.IsExistingTarget(cid.tgfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,eg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.tgfilter),tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,eg)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		local gg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gg,1,0,0)
	end
end
function cid.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and eg:IsExists(cid.cfilter,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=eg:FilterSelect(tp,cid.cfilter,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.Overlay(g:GetFirst(),Group.FromCards(tc))
		end
	end
end