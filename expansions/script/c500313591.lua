--Sinister Girl of Evil Vine
function c500313591.initial_effect(c)
	--synchro custom
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetTarget(c500313591.syntg)
	e4:SetValue(1)
	e4:SetOperation(c500313591.synop)
	c:RegisterEffect(e4)
	--synlimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetValue(c500313591.synlimit)
	c:RegisterEffect(e5)
		--flip effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e2:SetOperation(c500313591.flipop)
	c:RegisterEffect(e2)
		--Negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(500313591,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,500313591+EFFECT_COUNT_CODE_OATH)
	e3:SetCondition(c500313591.condition)
	e3:SetTarget(c500313591.target)
	e3:SetOperation(c500313591.operation)
	c:RegisterEffect(e3)
end

function c500313591.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		c:RegisterFlagEffect(500313591,RESET_EVENT+0x57a0000,0,0)
	end
end
function c500313591.condition(e,tp,eg,ep,ev,re,r,rp)
	return  rp~=tp
		and re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP)or re:IsActiveType(TYPE_MONSTER)  and Duel.IsChainNegatable(ev)
end


function c500313591.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(500313591)~=0 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
	end
end
function c500313591.operation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENCE)
	Duel.NegateActivation(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
end

function c500313591.synfilter(c,syncard,tuner,f)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x485a) and  c:IsNotTuner(syncard)
		and c:IsCanBeSynchroMaterial(syncard,tuner) and (f==nil or f(c))
end
function c500313591.syntg(e,syncard,f,minc,maxc)
	local c=e:GetHandler()
	local lv=syncard:GetLevel()-c:GetLevel()
	if lv<=0 then return false end
	local g=Duel.GetMatchingGroup(c500313591.synfilter,syncard:GetControler(),LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,c,syncard,c,f)
	return g:CheckWithSumEqual(Card.GetSynchroLevel,lv,minc,maxc,syncard)
end
function c500313591.synop(e,tp,eg,ep,ev,re,r,rp,syncard,f,minc,maxc)
	local c=e:GetHandler()
	local lv=syncard:GetLevel()-c:GetLevel()
	local g=Duel.GetMatchingGroup(c500313591.synfilter,syncard:GetControler(),LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,c,syncard,c,f)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local sg=g:SelectWithSumEqual(tp,Card.GetSynchroLevel,lv,minc,maxc,syncard)
	Duel.SetSynchroMaterial(sg)
end
function c500313591.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x485a)
end
