--Raggio di Speranza tra gli AoJ, Mariame
--Script by XGlitchy30
function c19772587.initial_effect(c)
	--set limit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_LIMIT_SET_PROC)
	e0:SetCondition(c19772587.setcon)
	c:RegisterEffect(e0)
	--special summon condition
	local e00=Effect.CreateEffect(c)
	e00:SetType(EFFECT_TYPE_SINGLE)
	e00:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e00:SetCode(EFFECT_SPSUMMON_CONDITION)
	e00:SetValue(0)
	c:RegisterEffect(e00)
	--special summon
	local e000=Effect.CreateEffect(c)
	e000:SetDescription(aux.Stringid(19772587,0))
	e000:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e000:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e000:SetCode(EVENT_ATTACK_ANNOUNCE)
	e000:SetRange(LOCATION_HAND)
	e000:SetCountLimit(1,19772587+EFFECT_COUNT_CODE_DUEL)
	e000:SetCondition(c19772587.spcon)
	e000:SetCost(c19772587.spcost)
	e000:SetTarget(c19772587.sptg)
	e000:SetOperation(c19772587.spop)
	c:RegisterEffect(e000)
	--unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c19772587.imcon)
	e1:SetOperation(c19772587.imop)
	c:RegisterEffect(e1)
	--normalsum restriction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19772587,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_DEFCHANGE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetOperation(c19772587.restriction)
	c:RegisterEffect(e2)
end
--filters
--set limit
function c19772587.setcon(e,c,minc)
	if not c then return true end
	return false
end
--special summon
function c19772587.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=0
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==1
end
function c19772587.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetDecktopGroup(tp,5)
	if chk==0 then return rg:FilterCount(Card.IsAbleToRemove,nil)==5 end
	if rg:GetCount()>=5 then
		Duel.Remove(rg,POS_FACEUP,REASON_COST)
	end
end
function c19772587.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,true,true,POS_FACEUP_DEFENSE) --spsum check
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=0
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==1
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19772587.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,1,tp,tp,true,false,POS_FACEUP_DEFENSE)~=0 then
		c:CompleteProcedure()
	end
end
--unaffected
function c19772587.imcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function c19772587.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	e1:SetValue(c19772587.immune)
	e1:SetOwnerPlayer(tp)
	c:RegisterEffect(e1)
end
function c19772587.immune(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
--normalsum restriction
function c19772587.restriction(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(c:GetDefense()/2)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		c:RegisterEffect(e1)
	end
end