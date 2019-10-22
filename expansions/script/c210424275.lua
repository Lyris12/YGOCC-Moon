--Moon Burst's Fallen Feather
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4066,8))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cid.betarget)
	e1:SetTarget(cid.damtg1)
	e1:SetOperation(cid.damop1)
	c:RegisterEffect(e1)
		--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(cid.spcon)
	c:RegisterEffect(e2)
		--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetDescription(aux.Stringid(4066,3))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(cid.condition)
	e3:SetCost(cid.cost)
	e3:SetOperation(cid.operation)
	c:RegisterEffect(e3)
end
function cid.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x666)
end
function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(cid.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (d and d:GetControler()==tp and d:IsSetCard(0x666) and d:IsRelateToBattle())
		
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	if Duel.GetTurnPlayer()~=tp then a=Duel.GetAttackTarget() end
	if not a:IsRelateToBattle() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(1000)
	a:RegisterEffect(e1)
end
function cid.filter2(c,tp)
	return  not c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
end
function cid.betarget(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:GetHandler():IsSetCard(0x666)  or not re:GetHandler():IsControler(tp) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(cid.filter2,1,nil,tp)
end
function cid.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false))
	or (e:GetHandler():IsAbleToHand()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function cid.damop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and (not c:IsAbleToHand()) then return end
	-- ^if you cannot add and cannot special summon, do nothing
	local option
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then option=0 end
	if c:IsAbleToHand() then option=1 end
	if (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) and c:IsAbleToHand() then
		option=Duel.SelectOption(tp,aux.Stringid(4066,7),aux.Stringid(4066,8)) end
	if option==0 then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	if option==1 then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end