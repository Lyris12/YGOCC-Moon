--La Caccia di una Bestia Bushido
--Script by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4b0))
	e2:SetValue(100)
	c:RegisterEffect(e2)
	--recover
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:HOPT(true)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
	--activate effect
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:HOPT(true)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b0) and c:IsMonster()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ct*100)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE+LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if ct<=0 then return end
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Recover(p,ct*100,REASON_EFFECT)
end

function s.filter(c,f)
	if c:IsCode(id) then return false end
	return c:IsSetCard(0x4b0) and (c:IsMonster() or c:IsST()) and f(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,Card.IsAbleToHand)
	local b2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,Card.IsAbleToGrave)
	if chk==0 then return b1 or b2 end
	e:SetCategory(0)
	local opt=aux.Option(id,tp,1,b1,b2)
	if opt==0 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	elseif opt==1 then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
	end
	e:SetLabel(opt)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain() then return end
	local opt=e:GetLabel()
	if opt==0 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,Card.IsAbleToHand)
		if #g>0 then
			Duel.Search(g,tp)
		end
	elseif opt==1 then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,Card.IsAbleToGrave)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end