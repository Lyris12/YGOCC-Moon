--Obstacle Ennigmaterial
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_XYZATTACH)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(cid.spcon)
	e1:SetTarget(cid.sptg)
	e1:SetOperation(cid.spop)
	c:RegisterEffect(e1)
	--protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(aux.TargetBoolFunction(aux.NOT(Card.IsCode),id))
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2x:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetTargetRange(LOCATION_MZONE,0)
	e2x:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsCode),id))
	e2x:SetValue(aux.tgoval)
	c:RegisterEffect(e2x)
	--double def
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cid.defcon)
	e3:SetOperation(cid.defop)
	c:RegisterEffect(e3)
end
--filters
function cid.xyzoverlay(c)
	return c:IsFaceup() and c:IsSetCard(0xead) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function cid.spcfilter(c,tp)
	local check=true
	local g=Duel.GetMatchingGroup(cid.xyzoverlay,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		if tc:GetOverlayGroup():IsContains(c) then
			check=true
		end
	end
	return check
end
--spsummon
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and ev>0 and eg:IsExists(cid.spcfilter,1,nil,tp)
		and Duel.GetFlagEffect(tp,id)==0
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
--protection
function cid.atlimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0xead)
end
function cid.tglimit(e,c)
	return c:IsSetCard(0xead) and c~=e:GetHandler()
end
--double def
function cid.defcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
function cid.defop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e1:SetValue(e:GetHandler():GetDefense()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	e:GetHandler():RegisterEffect(e1)
end