--Imprigionamento nel Carcere di Soletluna
--Script by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--todeck
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsFaceup() and not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsAbleToChangeControler() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,c)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_PANDEMONIUM) and c:IsSetCard(0x209)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not c:IsInBackrow() and not c:IsType(TYPE_FIELD) then
			ft=ft-1
		end
		return ft>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_FACEUP,true,tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and not tc:IsForbidden() and tc:CheckUniqueOnField(tp) and tc:IsAbleToChangeControler() and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 then
		local g=Duel.Select(HINTMSG_EQUIP,false,tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,tc)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.EquipAndRegisterLimit(tp,tc,g:GetFirst())
		end
	end
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		if not (en and en:IsMonster() and en:IsSetCard(0x209) and c:IsAbleToDeck()) then return false end
		for i=1,3 do
			if en:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then
				return true
			end
		end
		return false
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if not (en and en:IsMonster() and en:IsSetCard(0x209)) then return end
	local valid_nums={}
	for i=1,3 do
		if en:IsCanUpdateEnergy(i,tp,REASON_EFFECT) then
			table.insert(valid_nums,i)
		end
	end
	if #valid_nums==0 then return end
	local ct=Duel.AnnounceNumber(tp,table.unpack(valid_nums))
	local _,diff=en:UpdateEnergy(ct,tp,REASON_EFFECT,true,c)
	if diff>0 and c:IsRelateToChain() and aux.PLChk(c,tp,LOCATION_GRAVE) then
		Duel.ShuffleIntoDeck(c,nil,REASON_EFFECT)
	end
end