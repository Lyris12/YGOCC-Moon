--Flamiller Venomperor
function c1242354358.initial_effect(c)
	c:EnableReviveLimit()
	

--protect
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1242354358.pcon)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(c1242354358.tglimit)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)



--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1242354358,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetTarget(c1242354358.target)
	e2:SetOperation(c1242354358.activate)
	c:RegisterEffect(e2)
end

--effs

--protection
function c1242354358.pcon(e,c)
	if c==nil then return true end
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_GRAVE)>=5

end

function c1242354358.tglimit(e,c)
	return c:IsSetCard(0x786) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end

--s/t pop


function c1242354358.afilter(c)
	return c:IsSetCard(0x786) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end

function c1242354358.bfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end


function c1242354358.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c1242354358.bfilter,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.IsExistingTarget(c1242354358.afilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,c1242354358.afilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,c1242354358.bfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function c1242354358.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end


















