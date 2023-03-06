--Il Severo Protettore di Soletluna, Balthus
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
	p1:SetCondition(s.actcon)
	p1:SetTarget(s.acttg)
	p1:SetOperation(s.actop)
	c:RegisterEffect(p1)
	aux.EnablePandemoniumAttribute(c,p1,true,TYPE_PANDEMONIUM+TYPE_EFFECT)
	--protect
	local p2=Effect.CreateEffect(c)
	p2:SetType(EFFECT_TYPE_FIELD)
	p2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	p2:SetRange(LOCATION_SZONE)
	p2:SetTargetRange(LOCATION_MZONE,0)
	p2:SetCondition(aux.PandActCheck)
	p2:SetTarget(s.tglimit)
	p2:SetValue(1)
	c:RegisterEffect(p2)
	--search
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
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
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DDD)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:HOPT()
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return e:IsHasType(EFFECT_TYPE_ACTIVATE) and aux.PandActCheck(e)
end
function s.eqfilter(c,tp)
	return c:IsMonster() and c:IsFaceup() and not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsAbleToChangeControler()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and s.eqfilter(chkc,tp) end
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)+1
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsInBackrow() and not c:IsType(TYPE_FIELD) then
			ft=ft-1
		end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,tp,c)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x209,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,700,3100,7,RACE_AQUA,ATTRIBUTE_WATER)
		and ft>0 and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_REMOVED,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_REMOVED,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,1-tp,LOCATION_REMOVED)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,tp,c)
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x209,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,700,3100,7,RACE_AQUA,ATTRIBUTE_WATER) then
		return
	end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_PANDEMONIUM)
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsControler(1-tp) and s.eqfilter(tc,tp) then
			Duel.EquipAndRegisterLimit(tp,tc,c,false)
		end
	end
end

function s.tglimit(e,c)
	return c:IsType(TYPE_DRIVE) and c:IsSetCard(0x209)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.thfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(0x209) and c:IsAbleToHand()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
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

function s.filter(c,tp)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:GetOwner()==1-tp
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.filter,nil,tp)
	if #g<=0 then return false end
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	return p==1-tp and loc==LOCATION_HAND
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=Duel.GetEngagedCard(tp)
	if chk==0 then
		return dc and dc:IsSetCard(0x209) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and dc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_DRIVE,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.SetTargetCard(dc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,dc,1,dc:GetControler(),dc:GetLocation())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() or not tc:IsSetCard(0x209) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(tc,SUMMON_TYPE_DRIVE,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		tc:CompleteProcedure()
	end
end