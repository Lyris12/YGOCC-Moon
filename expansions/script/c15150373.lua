--Parapsiche Specchio
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--negate attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCustomCategory(CATEGORY_REDIRECT_ATTACK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(s.nacon)
	e3:SetTarget(s.natg)
	e3:SetOperation(s.naop)
	c:RegisterEffect(e3)
end
s.listed_series = {0xa4a}

function s.tgfilter(c,e)
	return c:IsMonster() and c:IsPosition(POS_FACEUP_ATTACK) and c:GetColumnGroup():IsContains(e:GetHandler()) and c:IsCanChangePosition()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,POS_FACEUP_DEFENSE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)>0 and tc:IsPosition(POS_FACEUP_DEFENSE) and c:IsFaceup() and c:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetCondition(s.rcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetLabelObject(e1)
		e2:SetCondition(s.rcon2)
		e2:SetValue(s.aclimit)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.rcon(e)
	if not e:GetOwner():IsHasCardTarget(e:GetHandler()) then
		e:Reset()
		return false
	end
	return true
end
function s.rcon2(e)
	if not e:GetLabelObject() or aux.GetValueType(e:GetLabelObject())~="Effect" or not e:GetLabelObject().GetLabelObject or not e:GetOwner():IsHasCardTarget(e:GetLabelObject():GetHandler()) then
		e:Reset()
		return false
	end
	return true
end
function s.aclimit(e,re)
	if not e:GetLabelObject() or aux.GetValueType(e:GetLabelObject())~="Effect" or not e:GetLabelObject().GetLabelObject then return false end
	return re:GetHandler()==e:GetLabelObject():GetHandler()
end

function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at and at:IsControler(tp) and a:IsControler(1-tp)
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local a=Duel.GetAttacker()
		if a:CanAttack() and #a:GetAttackableTarget()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
			local g=a:GetAttackableTarget():FilterSelect(tp,s.filter,1,1,nil,tp)
			if #g>0 and not a:IsImmuneToEffect(e) then
				Duel.CalculateDamage(a,g:GetFirst())
			end
		end
	end
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0xa4a) and c:IsControler(tp)
end