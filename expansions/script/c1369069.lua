--Special Operative, "C" Ranger MAXX White
function c1369069.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(c1369069.matfilter),4,2)
	c:EnableReviveLimit()
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1369069,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c1369069.thtg)
	e1:SetOperation(c1369069.thop)
	e1:SetCountLimit(1,1369069)
	c:RegisterEffect(e1)
	--choose
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1369069,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(c1369069.cost)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c1369069.targ)
	e2:SetOperation(c1369069.op)
	e2:SetCountLimit(1,1369169)
	c:RegisterEffect(e2)
	--burn
	local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EVENT_BATTLE_DAMAGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(c1369069.damageflag)
	--	e3:SetCondition(c1369069.battledamage)
    c:RegisterEffect(e3)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1369069,0))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,1369269)
	e4:SetCondition(c1369069.condition)
	e4:SetTarget(c1369069.target)
	e4:SetOperation(c1369069.operation)
	c:RegisterEffect(e4)
end
function c1369069.matfilter(c)
    return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_INSECT)
end
function c1369069.spfilter(c,e,tp)
    return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function c1369069.thfilter(c)
	return ((c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_EARTH)) or c:IsCode(58012707)) and c:IsAbleToHand()
end
function c1369069.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c1369069.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c1369069.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c1369069.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c1369069.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c1369069.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c1369069.targ(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local b1=Duel.IsExistingTarget(c1369069.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp)
	local b2=Duel.IsExistingMatchingCard(c1369069.desfilter,tp,0,LOCATION_ONFIELD,1,e:GetHandler())
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(1369069,0),aux.Stringid(1369069,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(1369069,0))
	elseif b2 then
		op=Duel.SelectOption(tp,aux.Stringid(1369069,1))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c1369069.spfilter),tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	elseif op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
	end
end
function c1369069.op(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif sel==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,c1369069.desfilter,tp,0,LOCATION_ONFIELD,1,1,e:GetHandler())
		if g:GetCount()>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

function c1369069.damageflag(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(1369069,RESET_PHASE+PHASE_END+RESETS_STANDARD,0,1)
end
function c1369069.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(1369069)==0 and tp==Duel.GetTurnPlayer()
end
function c1369069.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsRace(RACE_INSECT) end,tp,LOCATION_MZONE,0,nil)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct*500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function c1369069.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsRace(RACE_INSECT) end,tp,LOCATION_MZONE,0,nil)*500
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,ct,REASON_EFFECT)
end
