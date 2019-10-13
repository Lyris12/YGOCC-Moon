--Mantra Beast
--Automate ID
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local scard=_G[str]
	local s_id=tonumber(string.sub(str,2))
	return scard,s_id
end

local scard,s_id=getID()

function scard.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,Card.IsMantra,4,2)
	--Send
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(s_id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(scard.tar)
	e1:SetCost(scard.cost)
	e1:SetOperation(scard.activate)
	e1:SetCountLimit(1,s_id)
	c:RegisterEffect(e1)
	--Recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(s_id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(scard.con)
	e2:SetTarget(scard.target)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(scard.cost)
	e2:SetCountLimit(1,s_id)
	e2:SetOperation(scard.operation)
	c:RegisterEffect(e2)
	if not scard.global_check then
		scard.global_check=true
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		ge2:SetOperation(scard.archchk)
		Duel.RegisterEffect(ge2,0)
	end
end
function scard.archchk(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(0,30000)==0 then 
		Duel.CreateToken(tp,30000)
		Duel.CreateToken(1-tp,30000)
		Duel.RegisterFlagEffect(0,30000,0,0,0)
		aux.AddXyzProcedure(e:GetHandler(),Card.IsMantra,4,2)
	end
end
function scard.filter(c)
	return c:IsMantra() and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function scard.afilter(c)
	return c:IsFaceup()
end
function scard.tar(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(scard.filter,tp,LOCATION_DECK,0,1,nil)
end
function scard.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function scard.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,scard.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local sg=g:GetFirst()
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and sg:IsLocation(LOCATION_GRAVE) and Duel.GetMatchingGroupCount(scard.afilter,tp,0,LOCATION_MZONE,nil)>0
		and Duel.SelectYesNo(tp,aux.Stringid(s_id,3)) then
			local g=Duel.SelectMatchingCard(tp,scard.afilter,tp,0,LOCATION_MZONE,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				Duel.BreakEffect()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-1000)
				e1:SetReset(RESET_EVENT+0x1fe0000)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e2)
			end
		end
	end
end

function scard.handfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c:IsMantra() and not c:IsType(TYPE_XYZ) and c:IsAbleToHand()
end
function scard.con(e,tp,c,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(scard.handfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and handfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(scard.handfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,scard.handfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsControler(tp)
	and tc:IsAttribute(ATTRIBUTE_DARK) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(s_id,2))
	then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
