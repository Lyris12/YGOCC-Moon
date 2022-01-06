--Barian Authority
local ref,id=GetID()
function ref.initial_effect(c)
	local magick=Effect.CreateEffect(c)
	magick:SetDescription(aux.Stringid(id,0))
	magick:SetCategory(CATEGORY_DRAW)
	magick:SetType(EFFECT_TYPE_TRIGGER_O)
	magick:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET)
	magick:SetTarget(ref.drtg)
	magick:SetOperation(ref.drop)
	aux.AddMagickProcCustom(c,ref.magcon,magick,aux.TRUE,1)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(aux.dscon)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
end
function ref.magcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsType(TYPE_MONSTER)
end
function ref.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,0)
end
function ref.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PLAYER)
	Duel.Draw(p,d,REASON_EFFECT)
end

function ref.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(ref.ssfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
function ref.ssfilter(c,e,tp,mc)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x1048,0x1073)
		and c:IsRace(mc:GetRace()) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(mc:GetControler(),tp,mc,c)>0
end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==1 then
			return false
		elseif e:GetLabel()==2 then
			return chkc:IsLocation(LOCATION_MZONE) and ref.xyzfilter(chkc,e,tp)
		else return false end
	end
	local _r,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_CHAINING,true)
	local negcon = _r and trp~=tp and Duel.IsChainNegatable(ev)
		and not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil)
	local xyzcon = Duel.IsExistingTarget(ref.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp)
	if chk==0 then return Duel.GetTurnPlayer()==tp and (negcon or xyzcon) end
	local opt=0
	if negcon and xyzcon then
		opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif negcon then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	else
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+2
	end
	if opt==0 or opt==1 then
		e:SetLabelObject(tre)
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,teg,1,0,0)
		if tre:GetHandler():IsDestructable() and tre:GetHandler():IsRelateToEffect(tre) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,teg,1,0,0)
		end
	end
	if opt==0 or opt==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local tc=Duel.SelectTarget(tp,ref.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp):GetFirst()
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			Duel.SetChainLimit(ref.limit(tc))
		end
	end
	e:SetLabel(opt)
end
function ref.limit(c)
	return  function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==0 or opt==1 then
		local ct=Duel.GetChainInfo(0,CHAININFO_CHAIN_COUNT)
		local tre=e:GetLabelObject()
		if Duel.NegateActivation(ct-1) and tre:GetHandler():IsRelateToEffect(tre) then
			Duel.Destroy(tre:GetHandler(),REASON_EFFECT)
		end
	end
	if opt==0 or opt==2 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
			local sp=tc:GetControler()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc):GetFirst()
			if sc then
				local mg=tc:GetOverlayGroup()
				if mg:GetCount()~=0 then
					Duel.Overlay(sc,mg)
				end
				sc:SetMaterial(Group.FromCards(tc))
				Duel.Overlay(sc,Group.FromCards(tc))
				Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,sp,false,false,POS_FACEUP)
				sc:CompleteProcedure()
			end
		end
	end
end
