--Abyss Actor - Brave Support
--scripted by Rawstone

local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--ATKup
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(s.atkval1)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10ec))
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(s.cond)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(s.cond)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id)
	e4:SetCost(aux.LabelCost2)
	e4:SetTarget(s.trg)   
	e4:SetOperation(s.ope)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4x)
	--hakai
	local e5=Effect.CreateEffect(c)
	e5:Desc(1)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCategory(CATEGORY_CONTROL+CATEGORY_ATKCHANGE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+100)
	e5:SetTarget(s.mfield)
	e5:SetOperation(s.chop)
	c:RegisterEffect(e5)
end
function s.atkval1(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,nil)*100
end

function s.confilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function s.cond(e)
	return Duel.IsExistingMatchingCard(s.confilter1,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

function s.filt(c,tp)
	return c:IsSetCard(0x10ec) and c:IsFaceup() and c:IsAbleToDeckAsCost() and c:IsType(TYPE_PENDULUM)
		and Duel.IsExistingMatchingCard(s.filt2,tp,LOCATION_DECK,0,1,c,{c:GetCode()})
end
function s.filt2(c,codes)
	return c:IsSetCard(0x10ec) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(table.unpack(codes))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filt,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filt,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.SendtoDeck(g:GetFirst(),nil,2,REASON_COST)
end

function s.trg(e,tp,eg,ep,ev,re,r,rp,chk)
	local l1,l2=e:GetLabel()
	if chk==0 then
		if l1~=1 then return false end
		e:SetLabel(0,l2)
		return Duel.IsExistingMatchingCard(s.filt,tp,LOCATION_EXTRA,0,1,nil,tp)
	end
	e:SetLabel(0,l2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filt,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_COST)
		local codes={tc:GetCode()}
		e:SetLabel(l1,table.unpack(codes))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.ope(e,tp,eg,ep,ev,re,r,rp)
	local codes={e:GetLabel()}
	table.remove(codes,1)
	if #codes==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filt2,tp,LOCATION_DECK,0,1,1,nil,codes)
	if g:GetCount()>0 then
		Duel.Search(g,tp)
	end
end

function s.chfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsAbleToChangeControler() 
end
function s.gfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ec)
end
function s.mfield(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.chfilter(chkc) end
	local g=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	if chk==0 then
		return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
			and Duel.IsExistingTarget(s.chfilter,tp,LOCATION_MZONE,0,1,nil) and #g>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tg=Duel.SelectTarget(tp,s.chfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #tg>0 then
		local tc=tg:GetFirst()
		Duel.SetCardOperationInfo(tc,CATEGORY_CONTROL)
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tc:GetControler(),tc:GetLocation(),{0})
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,tg:GetFirst():GetAttack())
	end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetFirstTarget()
	if a and a:IsRelateToChain() and a:IsControler(tp) and Duel.GetControl(a,1-tp) and aux.PLChk(a,1-tp,LOCATION_MZONE) and a:IsFaceup() then
		local c=e:GetHandler()
		local preatk=a:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(0)
		a:RegisterEffect(e1)
		if not a:IsImmuneToEffect(e1) and preatk>0 and a:GetAttack()==0 then
			local g=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_MZONE,0,nil)
			for tc in aux.Next(g) do
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(preatk)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
end





















