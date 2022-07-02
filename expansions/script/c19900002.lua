--Serpenterfly of Fiber Vine
local cid,id=GetID()
function cid.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(cid.spcon)
	 e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
			--summon success
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(cid.thtg)
	e2:SetOperation(cid.thop)
	c:RegisterEffect(e2)
		local e0=e2:Clone()
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e0)
		--lv change
	--local e3=Effect.CreateEffect(c)

	--e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	--e3:SetType(EFFECT_TYPE_IGNITION)
	--e3:SetRange(LOCATION_MZONE)
	--e3:SetCountLimit(1)
	--e3:SetTarget(cid.target)
	--e3:SetOperation(cid.operation)
	--c:RegisterEffect(e3)
end
function cid.spcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)==0
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(cid.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end

function cid.splimit(e,c)
	return not  c:IsSetCard(0x85a) and c:GetLocation(LOCATION_EXTRA)
end

function cid.thfilter(c)
	return c:IsSetCard(0x185a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--function cid.filter(c)
	--return c:IsFaceup() and c:IsSetCard(0x185a) and c:IsLevelAbove(1)
--end
--function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
--  if chkc then return chkc:IsLocation(LOCATION_MZONE) and cid.filter(chkc) end
--  if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
--  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
--  local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
--  local tc=g:GetFirst()
	--local op=0
	--if tc:GetLevel()==1 then op=Duel.SelectOption(tp,aux.Stringid(id,1))
--  else op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) end
--- e:SetLabel(op)
--end
--function cid.operation(e,tp,eg,ep,ev,re,r,rp)
--- local c=e:GetHandler()
----	local tc=Duel.GetFirstTarget()
--  if tc:IsFaceup() and tc:IsRelateToEffect(e) then
	--  local e1=Effect.CreateEffect(c)
	--  e1:SetType(EFFECT_TYPE_SINGLE)
	--  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	--  e1:SetCode(EFFECT_UPDATE_LEVEL)
	--  e1:SetReset(RESET_EVENT+0x1fe0000)
	--  if e:GetLabel()==0 then
	--  e1:SetValue(1)
	--  else e1:SetValue(-1) end
	--  tc:RegisterEffect(e1)
	--end
--end
