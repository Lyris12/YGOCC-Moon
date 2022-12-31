--Cascata Nottesfumo della Rimozione
--Script by XGlitchy30
function c62613317.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,62613317)
	e1:SetCondition(c62613317.condition)
	e1:SetTarget(c62613317.target)
	e1:SetOperation(c62613317.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,62613317)
	e4:SetTarget(c62613317.reptg)
	e4:SetValue(c62613317.repval)
	e4:SetOperation(c62613317.repop)
	c:RegisterEffect(e4)
end
--filters
function c62613317.filter(c)
	return c:IsSetCard(0x6233) and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_SYNCHRO+TYPE_XYZ) and c:IsFaceup()
end
function c62613317.cfilter(c,e)
	return (not e or c:IsRelateToEffect(e))
end
function c62613317.repfilter(c,tp)
	return c:IsFaceup() and c:IsOnField() and c:IsControler(tp) and not c:IsReason(REASON_REPLACE)
end
--Activate
function c62613317.condition(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetCount()~=1 then return false end
	local tc=eg:GetFirst()
	return tc~=e:GetHandler() and tc:GetSummonPlayer()==1-tp and Duel.IsExistingMatchingCard(c62613317.filter,tp,LOCATION_MZONE,0,1,nil)
end
function c62613317.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c62613317.cfilter,1,nil,nil) and eg:GetCount()==1 end
	local g=eg:Filter(c62613317.cfilter,nil,nil)
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c62613317.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c62613317.cfilter,nil,e)
	if g:GetCount()>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--destroy replace
function c62613317.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c62613317.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c62613317.repval(e,c)
	return c62613317.repfilter(c,e:GetHandlerPlayer())
end
function c62613317.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end