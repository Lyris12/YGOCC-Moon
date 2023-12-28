--Neo World Sky Platform
function c249001251.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c249001251.tgcon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--send and draw
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,2490012511)
	e3:SetTarget(c249001251.target)
	e3:SetOperation(c249001251.operation)
	c:RegisterEffect(e3)
	--reveal and draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35762283,0))
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DRAW)
	e4:SetCountLimit(1,2490012512)
	e4:SetCost(c249001251.drcost)
	e4:SetTarget(c249001251.drtg)
	e4:SetOperation(c249001251.drop)
	c:RegisterEffect(e4)
end
function c249001251.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x236)
end
function c249001251.tgcon(e)
	return Duel.IsExistingMatchingCard(c249001251.tgfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c249001251.filter(c)
	return ((c:IsLocation(LOCATION_HAND) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x236))
		or (c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x236)))
		and c:IsAbleToGrave()
end
function c249001251.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(c249001251.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001251.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c249001251.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function c249001251.drfilter(c)
	return c:IsSetCard(0x236) and not c:IsPublic()
end
function c249001251.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp and eg:IsExists(c249001251.drfilter,1,nil) end
	local g=eg:Filter(c249001251.drfilter,nil)
	if g:GetCount()==1 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
	end
end
function c249001251.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001251.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
