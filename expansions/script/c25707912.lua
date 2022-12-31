--Sylralei, Wisprit Guardian
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.thcost)
	e1:SetTarget(cid.thtg)
	e1:SetOperation(cid.thop)
	c:RegisterEffect(e1)
	--chain eff
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+17)
	e4:SetCondition(cid.condition)
	e4:SetCost(cid.cost)
	e4:SetTarget(cid.target)
	e4:SetOperation(cid.operation)
	c:RegisterEffect(e4)
	if not cid.global_check then
		cid.global_check=true
		--register previous chains
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(cid.chainreg)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetOperation(cid.negatedchainreg)
		Duel.RegisterEffect(ge2,0)
		--reset for turn
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge3:SetOperation(cid.resetchainreg)
		Duel.RegisterEffect(ge3,0)
	end
end
--GLOBAL VARIABLES AND GENERIC FILTERS
cid.chaintyp={[0]=0,[1]=0}
cid.chaincount={[0]={0,0,0},[1]={0,0,0}}
cid.regulate_negated_activation={[0]=false,[1]=false}
--REGISTER PREVIOUS CHAINS
function cid.chainreg(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	if rp==p or not re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) then return end
	if cid.chaintyp[rp]==0 or bit.band(cid.chaintyp[rp],bit.band(re:GetActiveType(),TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP))==0 then
		if bit.band(cid.chaintyp[rp],TYPE_SPELL)==0 then
			cid.regulate_negated_activation[rp]=TYPE_SPELL
		elseif bit.band(cid.chaintyp[rp],TYPE_TRAP)==0 then
			cid.regulate_negated_activation[rp]=TYPE_TRAP
		end
	end
	cid.chaintyp[rp]=bit.bor(cid.chaintyp[rp],bit.band(re:GetActiveType(),TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP))
	if bit.band(cid.chaintyp[rp],TYPE_MONSTER)>0 then
		cid.chaincount[rp][1]=cid.chaincount[rp][1]+1
	end
	if bit.band(cid.chaintyp[rp],TYPE_SPELL)>0 then
		cid.chaincount[rp][2]=cid.chaincount[rp][2]+1
	end
	if bit.band(cid.chaintyp[rp],TYPE_TRAP)>0 then
		cid.chaincount[rp][3]=cid.chaincount[rp][3]+1
	end
end
function cid.negatedchainreg(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	if rp==p or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not cid.regulate_negated_activation[rp] then return end
	cid.chaintyp[rp]=bit.band(cid.chaintyp[rp],bit.bnot(cid.regulate_negated_activation[rp]))
	if cid.regulate_negated_activation[rp]==TYPE_SPELL then
		cid.chaincount[rp][2]=cid.chaincount[rp][2]-1
	elseif cid.regulate_negated_activation[rp]==TYPE_TRAP then
		cid.chaincount[rp][3]=cid.chaincount[rp][3]-1
	end
	cid.regulate_negated_activation[rp]=false
end
--RESET FOR TURN
function cid.resetchainreg(e,tp,eg,ep,ev,re,r,rp)
	cid.chaintyp={[0]=0,[1]=0}
	cid.regulate_negated_activation={[0]=false,[1]=false}
	cid.chaincount={[0]={0,0,0},[1]={0,0,0}}
end
--filters
function cid.thfilter(c)
	return c:IsCode(25707917) and c:IsAbleToHand()
end
function cid.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cid.tgfilter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
--tohand
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		and Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
	   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	   local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	   if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	  end
   end
end
--chain eff
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and cid.chaintyp[rp]~=0
		and ((re:IsActiveType(TYPE_MONSTER) and cid.chaincount[rp][1]>1) or (re:IsActiveType(TYPE_SPELL) and cid.chaincount[rp][2]>1) or (re:IsActiveType(TYPE_TRAP) and cid.chaincount[rp][3]>1))
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b={true,true,true}
	b[1]=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_HAND,1,nil)
	b[2]=Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil)
	b[3]=Duel.IsExistingMatchingCard(cid.tgfilter1,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return (b[1] or b[2] or b[3]) and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	local rt=3
	for i=1,3 do
		if not b[i] then rt=rt-1 end
	end
	if rt<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rct=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	if #rct<=0 then return end
	local ct=Duel.Remove(rct,POS_FACEUP,REASON_COST)
	if ct<=0 then return end
	local sel,off,maxsel=0,0,0
	repeat
		local ops={}
		local opval={}
		off=2
		if b[1] then
			ops[off-1]=aux.Stringid(id,3)
			opval[off-1]=1
			off=off+1
		end
		if b[2] then
			ops[off-1]=aux.Stringid(id,4)
			opval[off-1]=2
			off=off+1
		end
		if b[3] then
			ops[off-1]=aux.Stringid(id,5)
			opval[off-1]=3
			off=off+1
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		if opval[op]==1 then
			sel=sel+1
			maxsel=maxsel+1
			b[1]=false
		elseif opval[op]==2 then
			sel=sel+2
			maxsel=maxsel+1
			b[2]=false
		else
			sel=sel+4
			maxsel=maxsel+1
			b[3]=false
		end
		ct=ct-1
	until (ct==0 or maxsel>=3 or off<3)
	e:SetLabel(sel)
	if bit.band(sel,0x1)~=0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
	end
	if bit.band(sel,0x2)~=0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
	end
	if bit.band(sel,0x4)~=0 then
		local g=Duel.GetMatchingGroup(cid.tgfilter1,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if bit.band(sel,0x1)~=0 then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if g:GetCount()==0 then return end
		local sg=g:RandomSelect(tp,1)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	if bit.band(sel,0x2)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.HintSelection(g)
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	if bit.band(sel,0x4)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,cid.tgfilter1,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			Duel.HintSelection(g)
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end