--La Grande Lanciera degli AoJ, Valkyric Ivora
--Script by XGlitchy30
function c19772602.initial_effect(c)
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	--PENDULUM EFFECTS
	--scale
	local e1p=Effect.CreateEffect(c)
	e1p:SetType(EFFECT_TYPE_SINGLE)
	e1p:SetCode(EFFECT_CHANGE_LSCALE)
	e1p:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1p:SetRange(LOCATION_PZONE)
	e1p:SetCondition(c19772602.slcon)
	e1p:SetValue(5)
	c:RegisterEffect(e1p)
	local e2p=e1p:Clone()
	e2p:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e2p)
	--pierce
	local e3p=Effect.CreateEffect(c)
	e3p:SetType(EFFECT_TYPE_FIELD)
	e3p:SetCode(EFFECT_PIERCE)
	e3p:SetRange(LOCATION_PZONE)
	e3p:SetTargetRange(LOCATION_MZONE,0)
	e3p:SetTarget(c19772602.pierce)
	c:RegisterEffect(e3p)
	--extra attacks
	local e4p=Effect.CreateEffect(c)
	e4p:SetDescription(aux.Stringid(19772602,0))
	e4p:SetType(EFFECT_TYPE_IGNITION)
	e4p:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4p:SetRange(LOCATION_PZONE)
	e4p:SetCountLimit(1,19772602)
	e4p:SetCost(c19772602.sccost)
	e4p:SetTarget(c19772602.sctg)
	e4p:SetOperation(c19772602.scop)
	c:RegisterEffect(e4p)
	--MONSTER EFFECTS
	--spsummon condition
	--local e1=Effect.CreateEffect(c)
	--e1:SetType(EFFECT_TYPE_SINGLE)
--	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	--e1:SetCode(EFFECT_SPSUMMON_CONDITION)
--	e1:SetValue(c19772602.splimit)
--	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c19772602.sprcon)
	e2:SetOperation(c19772602.sprop)
	e2:SetValue(100663296)
	c:RegisterEffect(e2)
	--defense attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19772602,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c19772602.schtg)
	e4:SetOperation(c19772602.schop)
	c:RegisterEffect(e4)
	--pierce single
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--pendulum zone
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(19772602,2))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1)
	e6:SetCondition(c19772602.pendlcon)
	e6:SetCost(c19772602.pendlcost)
	e6:SetTarget(c19772602.pendltg)
	e6:SetOperation(c19772602.pendlop)
	c:RegisterEffect(e6)
end
--filters
function c19772602.slfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_XYZ)
end
function c19772602.eafilter(c)
	return c:IsFaceup() and c:IsSetCard(0x197)
end
function c19772602.scfilter(c)
	return c:IsSetCard(0x197) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c19772602.schfilter(c)
	return c:IsSetCard(0x197) and c:IsAbleToDeck()
end
--scale
function c19772602.slcon(e)
	return Duel.IsExistingMatchingCard(c19772602.slfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
--pierce
function c19772602.pierce(e,c)
	return c:IsSetCard(0x197) and c:IsPosition(POS_FACEUP_DEFENSE)
end
--extra attacks
function c19772602.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function c19772602.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19772602.eafilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19772602.eafilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c19772602.eafilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c19772602.scop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ATTACK_ALL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
--splimit and procedure
--function c19772602.splimit(e,se,sp,st)
	--return e:GetHandler():GetLocation()~=LOCATION_EXTRA
--end
function c19772602.sprfilter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsSetCard(0x197) and c:IsAbleToGraveAsCost()
end
function c19772602.sprfilter2(c,tp,mc)
	local sg=Group.FromCards(c,mc)
	return Duel.GetLocationCountFromEx(tp,tp,sg)>0
end
function c19772602.sprfilter1(c,g,tp)
	return g:IsExists(c19772602.sprfilter2,1,c,tp,c)
end
function c19772602.sprcon(e,c)
	if c==nil then return true end
	if c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) then return end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(c19772602.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(c19772602.sprfilter1,1,nil,g,tp) and g:CheckWithSumGreater(Card.GetLevel,12,1,99)
end
function c19772602.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.GetMatchingGroup(c19772602.sprfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=g:Filter(c19772602.sprfilter1,nil,g,tp)
	local mc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=g:Filter(c19772602.sprfilter2,mc,tp,mc)
	g1:Merge(g2)
	local mg=g1:SelectWithSumEqual(tp,Card.GetLevel,12,1,99)
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_COST+REASON_SYNCHRO+REASON_MATERIAL)
end
--search trap card
function c19772602.schtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772602.schfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function c19772602.schop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19772602.schfilter),tp,LOCATION_GRAVE,0,1,3,nil)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
--pendulum zone
function c19772602.pendlcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function c19772602.pendlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,LOCATION_PZONE)
	if chk==0 then return g:GetCount()>0 end
	Duel.SendtoGrave(g,REASON_COST)
end
function c19772602.pendltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function c19772602.pendlop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end