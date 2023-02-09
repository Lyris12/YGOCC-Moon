--La Spietata Guardiana di Soletluna, Melveth
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
	p2:SetCode(EFFECT_IMMUNE_EFFECT)
	p2:SetRange(LOCATION_SZONE)
	p2:SetTargetRange(LOCATION_MZONE,0)
	p2:SetCondition(aux.PandActCheck)
	p2:SetTarget(s.tglimit)
	p2:SetValue(s.efilter)
	c:RegisterEffect(p2)
	--search
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(s.negcon)
	e1:SetCost(aux.DiscardSelfCost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
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
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
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
	return c:IsMonster() and not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsAbleToChangeControler()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.eqfilter(chkc,tp) end
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)+1
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsInBackrow() and not c:IsType(TYPE_FIELD) then
			ft=ft-1
		end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp,0,POS_FACEUP,tp,c)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x209,TYPE_MONSTER+TYPE_EFFECT+TYPE_PANDEMONIUM,700,3100,7,RACE_AQUA,ATTRIBUTE_WATER)
		and ft>0 and Duel.IsExistingTarget(s.eqfilter,tp,0,LOCATION_GRAVE,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,1-tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,1-tp,0)
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
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=Duel.GetEngagedCard(tp)
	if not ec or not ec:IsMonster(TYPE_DRIVE) or not ec:IsSetCard(0x209) then return false end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return (re:IsActiveType(TYPE_ST) and re:IsHasType(EFFECT_TYPE_ACTIVATE)) and not rc:IsDisabled() and Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:IsRace(RACE_AQUA) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local dc=re:GetHandler()
	local relation=dc:IsRelateToChain(ev)
	if relation then
		if dc:IsDestructable(e) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,dc:GetControler(),dc:GetLocation())
			Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,0)
		end
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.enfilter(en,tp)
	return en and en:IsMonster() and en:GetLevel()>0 and en:IsSetCard(0x209) and en:IsCanUpdateEnergy(tp,en:GetLevel(),REASON_EFFECT)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not Duel.NegateEffect(ev) then return end
	if rc:IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0 and not (rc:IsLocation(LOCATION_HAND+LOCATION_DECK) or rc:IsLocation(LOCATION_REMOVED) and rc:IsFacedown())
		and aux.NecroValleyFilter()(rc) and rc:IsST() and not rc:IsType(TYPE_FIELD) then
		local en=Duel.GetEngagedCard(tp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and rc:IsSSetable() and s.enfilter(en,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			if Duel.SSet(tp,rc)>0 and aux.PLChk(rc,tp,LOCATION_SZONE) and rc:IsFacedown() then
				en=Duel.GetEngagedCard(tp)
				if s.enfilter(en,tp) then
					en:UpdateEnergy(en:GetLevel(),tp,REASON_EFFECT,0,e:GetHandler())
				end
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
	return p==1-tp and loc==LOCATION_GRAVE
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_GRAVE,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,Card.IsCanBeSpecialSummoned,tp,0,LOCATION_GRAVE,1,1,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,g:GetFirst():GetControler(),g:GetFirst():GetLocation())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end