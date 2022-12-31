--Glimlo of Evil Vine
function c160002020.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
		--synchro custom
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c160002020.synlimit)
	c:RegisterEffect(e2)
	--

	
		--search
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(160002020,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1,160002020)
	e4:SetRange(LOCATION_HAND)
	--e4:SetCondition(c160002020.con)
	e4:SetCost(c160002020.cost)
	e4:SetTarget(c160002020.tg)
	e4:SetOperation(c160002020.op)
	c:RegisterEffect(e4)
	--lv change
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(160002020,0))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1,160002021)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(c160002020.tg2)
	e5:SetOperation(c160002020.op2)
	c:RegisterEffect(e5)
end




function c160002020.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x485a) and not c:IsType(TYPE_ZOMBIE)
end
function c160002020.synlimit2(e,c)
	return not c:IsSetCard(0x485a)  and not c:IsType(TYPE_ZOMBIE)
	
end
function c160002020.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x485a)
end
function c160002020.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c160002020.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c160002020.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c160002020.filter(c)
	return c:IsSetCard(0x85a) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function c160002020.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c160002020.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c160002020.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c160002020.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c160002020.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local t={}
	local i=1
	local p=1
	local lv=e:GetHandler():GetLevel()
	for i=1,5 do 
		if lv~=i then t[p]=i p=p+1 end
	end
	t[p]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(160002020,1))
	e:SetLabel(Duel.AnnounceNumber(tp,table.unpack(t)))
end
function c160002020.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end