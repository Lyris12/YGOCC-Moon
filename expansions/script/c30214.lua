--Mantra Leech
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--SS Equip
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(scard.eqcon)
	e1:SetTarget(scard.eqtg)
	e1:SetOperation(scard.eqop)
	c:RegisterEffect(e1)
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(aux.DiscardCost(aux.MonsterFilter(Card.IsMantra)))
	e2:SetTarget(scard.destg)
	e2:SetOperation(scard.desop)
	c:RegisterEffect(e2)
end
function scard.eqcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return rc:IsMantra() and c:IsReason(REASON_EFFECT|REASON_COST)
end
function scard.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(Card.IsFaceup,1-tp,LOCATION_MZONE,0,1,nil)
			and not c:IsForbidden() and c:CheckUniqueOnField(tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,1-tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(c,CATEGORY_EQUIP)
	Duel.SetCustomOperationInfo(0,CATEGORY_EQUIP,g,#g,g:GetFirst():GetControler(),g:GetFirst():GetLocation(),c,1,c:GetControler(),c:GetLocation())
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetCardOperationInfo(c,CATEGORY_LEAVE_GRAVE)
	end
end
function scard.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not c:IsRelateToChain() or not (not c:IsForbidden() and c:CheckUniqueOnField(tp)) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.EquipAndRegisterLimit(tp,c,tc)
	end
end

function scard.somefilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
function scard.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec and ec:IsMonster() and ec:IsAbleToGrave() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetCardOperationInfo(ec,CATEGORY_TOGRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function scard.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not ec or not ec:IsMonster() then return end
	if Duel.SendtoGrave(ec,REASON_EFFECT)>0 and ec:IsLocation(LOCATION_GRAVE) then
		if Duel.IsPlayerCanDraw(tp,1) then
			Duel.BreakEffect()
		end
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
