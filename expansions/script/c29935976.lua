--Il Custode Silente di Soletluna, Alvarein
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--activate
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	p1:SetType(EFFECT_TYPE_QUICK_O)
	p1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	p1:SetCode(EVENT_FREE_CHAIN)
	p1:SetRange(LOCATION_SZONE)
	p1:HOPT()
	p1:SetCondition(s.actcon)
	p1:SetTarget(s.acttg)
	p1:SetOperation(s.actop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_PANDEMONIUM+TYPE_EFFECT)
	--protect
	local p2=Effect.CreateEffect(c)
	p2:SetType(EFFECT_TYPE_FIELD)
	p2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	p2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	p2:SetRange(LOCATION_SZONE)
	p2:SetTargetRange(LOCATION_MZONE,0)
	p2:SetCondition(aux.PandActCheck)
	p2:SetTarget(s.tglimit)
	p2:SetValue(s.tgval)
	c:RegisterEffect(p2)
	--search
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(s.rmcon)
	e1:SetCost(aux.DiscardSelfCost)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--tohand
	local e3=Effect.CreateEffect(c)
	e3:Desc(4)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:HOPT()
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) and aux.PandActCheck(e)
end
function s.eqfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsAbleToChangeControler()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.eqfilter(chkc,tp) end
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)+1
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsInBackrow() and not c:IsType(TYPE_FIELD) then
			ft=ft-1
		end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,tp,c)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x209,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,700,3100,7,RACE_AQUA,ATTRIBUTE_WATER)
		and ft>0 and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_MZONE,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,1-tp,LOCATION_MZONE)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,tp,c)
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x209,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,700,3100,7,RACE_AQUA,ATTRIBUTE_WATER) then
		return
	end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM)
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsControler(1-tp) and s.eqfilter(tc,tp) then
			Duel.EquipAndRegisterLimit(tp,tc,c,false)
		end
	end
end

function s.tglimit(e,c)
	return c:IsType(TYPE_DRIVE) and c:IsSetCard(0x209)
end
function s.tgval(e,re,rp)
	if not aux.tgoval(e,re,rp) or not re:IsActiveType(TYPE_MONSTER) then return false end
	local rc=re:GetHandler()
	return rc and rc:IsControler(1-e:GetHandlerPlayer()) and rc:IsLocation(LOCATION_MZONE)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.thfilter0(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(0x209) and c:IsAbleToHand()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter0,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter0,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		local tc=g:GetFirst()
		if aux.PLChk(tc,tp,LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
			if tc:IsCanEngage(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				tc:Engage(e,tp)
			end
		end
	end
end

function s.filter(c,rc)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and rc:IsOriginalCodeRule(c:GetOriginalCodeRule())
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local g=c:GetEquipGroup():Filter(Card.IsFaceup,nil)
	return #g>0 and re:IsActiveType(TYPE_MONSTER) and rc and g:IsExists(s.filter,1,nil,rc)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end

function s.thfilter(c)
	return c:IsSetCard(0x209) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end