--Pot's Desire
--Script by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:GLString(2)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,cid.chainfilter)
end
function cid.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(id))
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.filter(c)
	return c:IsCode(35261759)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(1-tp,10)
	local b1=(Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)<=1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsCode(id) and g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==10
			and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=12 and Duel.IsPlayerCanDraw(1-tp,2))
	local b2=(Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp,1))
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return b1 or b2
	end
	e:SetLabel(0)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,2)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			if Duel.SendtoHand(g,1-tp,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) and g:GetFirst():IsControler(1-tp) then
				Duel.ConfirmCards(tp,g)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
				e1:SetCode(EVENT_TO_GRAVE)
				e1:SetCondition(cid.rmcon)
				e1:SetOperation(cid.rmop)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOGRAVE)
				g:GetFirst():RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EVENT_REMOVE)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_REMOVE)
				g:GetFirst():RegisterEffect(e2)
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
function cid.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and e:GetHandler():GetPreviousControler()==1-tp and re and rp==1-tp
		and (bit.band(r,REASON_EFFECT)==REASON_EFFECT or (re:IsActivated() and bit.band(r,REASON_COST)==REASON_COST))
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	local g=Duel.GetDecktopGroup(1-tp,5)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end